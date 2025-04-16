use crate::error::Error;
use crate::reader::FlvReader;
use std::io::Seek;

fn parse_string<'a>(reader: &mut FlvReader<'a>, is_long_string: bool) -> Result<&'a [u8], Error> {
    let length = if is_long_string {
        reader.read_u32()?
    } else {
        reader.read_u16()? as u32
    };

    reader.read(length as usize)
}

#[repr(u8)]
#[derive(PartialEq, Debug, Clone)]
pub enum Value<'a> {
    Number(f64) = 0,
    Boolean(bool) = 1,
    String(&'a [u8]) = 2,
    Object(Vec<Variable<'a>>) = 3,
    MovieClip(&'a [u8]) = 4, // Is a string that defines a MovieClip path
    Null = 5,
    Undefined = 6,
    Reference(u16) = 7,
    EcmaArray(Vec<Variable<'a>>) = 8,
    StrictArray(Vec<Value<'a>>) = 10,
    Date {
        /// The number of milliseconds since January 1st, 1970.
        unix_time: f64,

        /// Local time offset in minutes from UTC.
        /// Time zones west of Greenwich, UK are negative.
        local_offset: i16,
    } = 11,
    LongString(&'a [u8]) = 12,
}

impl<'a> Value<'a> {
    /// Parse a script value.
    ///
    /// Strings are yielded as byte arrays, as there is no guidance in the FLV
    /// specification as to how they are to be decoded.
    ///
    /// data_size is the size of the entire script data structure.
    pub fn parse(reader: &mut FlvReader<'a>) -> Result<Self, Error> {
        let value_type = reader.read_u8()?;

        match value_type {
            0 => Ok(Self::Number(reader.read_f64()?)),
            1 => Ok(Self::Boolean(reader.read_u8()? != 0)),
            2 => Ok(Self::String(parse_string(reader, false)?)),
            3 => {
                let mut variables = vec![];
                loop {
                    let terminator = reader.peek_u24()?;
                    if terminator == 9 {
                        reader.read_u24()?;
                        return Ok(Self::Object(variables));
                    }

                    variables.push(Variable::parse(reader)?);
                }
            }
            4 => Ok(Self::MovieClip(parse_string(reader, false)?)),
            5 => Ok(Self::Null),
            6 => Ok(Self::Undefined),
            7 => Ok(Self::Reference(reader.read_u16()?)),
            8 => {
                let length_hint = reader.read_u32()?;
                let mut variables = Vec::with_capacity(length_hint as usize);

                loop {
                    let terminator = reader.peek_u24()?;
                    if terminator == 9 {
                        reader.read_u24()?;
                        return Ok(Self::EcmaArray(variables));
                    }

                    variables.push(Variable::parse(reader)?);
                }
            }
            10 => {
                let length = reader.read_u32()?;
                let mut values = Vec::with_capacity(length as usize);

                for _ in 0..length {
                    values.push(Value::parse(reader)?);
                }

                Ok(Self::StrictArray(values))
            }
            11 => Ok(Self::Date {
                unix_time: reader.read_f64()?,
                local_offset: reader.read_i16()?,
            }),
            12 => Ok(Self::LongString(parse_string(reader, true)?)),
            _ => Err(Error::UnknownValueType),
        }
    }
}

/// An individual object in a ScriptData tag.
///
/// This corresponds to both the `SCRIPTDATAOBJECT` and `SCRIPTDATAVARIABLE`
/// structures as defined in the FLV specification. These structures are
/// otherwise identical.
#[derive(PartialEq, Debug, Clone)]
pub struct Variable<'a> {
    pub name: &'a [u8],
    pub data: Value<'a>,
}

impl<'a> Variable<'a> {
    pub fn parse(reader: &mut FlvReader<'a>) -> Result<Self, Error> {
        Ok(Self {
            name: parse_string(reader, false)?,
            data: Value::parse(reader)?,
        })
    }
}

#[derive(PartialEq, Debug, Clone)]
pub struct ScriptData<'a>(pub Vec<Variable<'a>>);

impl<'a> ScriptData<'a> {
    /// Parse a script data structure.
    ///
    /// No data size parameter is accepted; we parse until we reach an object
    /// terminator, reach invalid data, or we run out of bytes in the reader.
    pub fn parse(reader: &mut FlvReader<'a>, data_size: u32) -> Result<Self, Error> {
        let start = reader.stream_position().expect("valid position");
        let _trash = reader.read_u8()?;
        let mut vars = vec![];

        loop {
            let cur_length = reader.stream_position().expect("valid position") - start;
            if cur_length >= data_size as u64 {
                // Terminators are commonly elided from script data blocks.
                return Ok(Self(vars));
            }

            let is_return = reader.peek_u24()?;
            if is_return == 9 {
                reader.read_u24()?;
                return Ok(Self(vars));
            }

            vars.push(Variable::parse(reader)?);
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::reader::FlvReader;
    use crate::script::{parse_string, ScriptData, Value, Variable};

    #[test]
    fn read_string() {
        let data = [0x00, 0x03, 0x01, 0x02, 0x03];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(parse_string(&mut reader, false), Ok(&data[2..]));
    }

    #[test]
    fn read_string_long() {
        let data = [0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(parse_string(&mut reader, true), Ok(&data[4..]));
    }

    #[test]
    fn read_value_number() {
        let data = [0x00, 0x40, 0x28, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(Value::parse(&mut reader), Ok(Value::Number(12.3)));
    }

    #[test]
    fn read_value_boolean() {
        let data = [0x01, 0x01];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(Value::parse(&mut reader), Ok(Value::Boolean(true)));
    }

    #[test]
    fn read_value_string() {
        let data = [0x02, 0x00, 0x03, 0x01, 0x02, 0x03];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::String(&[0x01, 0x02, 0x03]))
        );
    }

    #[test]
    fn read_value_movieclip() {
        let data = [0x04, 0x00, 0x03, 0x01, 0x02, 0x03];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::MovieClip(&[0x01, 0x02, 0x03]))
        );
    }

    #[test]
    fn read_value_longstring() {
        let data = [0x0C, 0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::LongString(&[0x01, 0x02, 0x03]))
        );
    }

    #[test]
    fn read_value_null() {
        let data = [0x05];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(Value::parse(&mut reader), Ok(Value::Null));
    }

    #[test]
    fn read_value_undefined() {
        let data = [0x06];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(Value::parse(&mut reader), Ok(Value::Undefined));
    }

    #[test]
    fn read_value_reference() {
        let data = [0x07, 0x24, 0x38];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(Value::parse(&mut reader), Ok(Value::Reference(0x2438)));
    }

    #[test]
    fn read_value_date() {
        let data = [
            0x0B, 0x40, 0x28, 0x99, 0x99, 0x99, 0x99, 0x99, 0x9a, 0xFF, 0xFE,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::Date {
                unix_time: 12.3,
                local_offset: -2
            })
        );
    }

    #[test]
    fn read_value_object() {
        let data = [
            0x03, 0x00, 0x03, 0x01, 0x02, 0x03, 0x06, 0x00, 0x03, 0x01, 0x02, 0x03, 0x05, 0x00,
            0x00, 0x09,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::Object(vec![
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Undefined
                },
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Null
                }
            ]))
        );
    }

    #[test]
    fn read_value_ecmaarray() {
        let data = [
            0x08, 0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x01, 0x02, 0x03, 0x06, 0x00, 0x03, 0x01,
            0x02, 0x03, 0x05, 0x00, 0x00, 0x09,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::EcmaArray(vec![
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Undefined
                },
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Null
                }
            ]))
        );
    }

    #[test]
    fn read_value_ecmaarray_longlen() {
        let data = [
            0x08, 0x00, 0x00, 0x0F, 0x02, 0x00, 0x03, 0x01, 0x02, 0x03, 0x06, 0x00, 0x03, 0x01,
            0x02, 0x03, 0x05, 0x00, 0x00, 0x09,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::EcmaArray(vec![
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Undefined
                },
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Null
                }
            ]))
        );
    }

    #[test]
    fn read_value_ecmaarray_shortlen() {
        let data = [
            0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x01, 0x02, 0x03, 0x06, 0x00, 0x03, 0x01,
            0x02, 0x03, 0x05, 0x00, 0x00, 0x09,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::EcmaArray(vec![
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Undefined
                },
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Null
                }
            ]))
        );
    }

    #[test]
    fn read_value_strictarray() {
        let data = [0x0A, 0x00, 0x00, 0x00, 0x02, 0x06, 0x05];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            Value::parse(&mut reader),
            Ok(Value::StrictArray(vec![Value::Undefined, Value::Null]))
        );
    }

    #[test]
    fn read_scriptdata() {
        let data = [
            0x02, 0x00, 0x03, 0x01, 0x02, 0x03, 0x06, 0x00, 0x03, 0x01, 0x02, 0x03, 0x05, 0x00,
            0x00, 0x09,
        ];
        let mut reader = FlvReader::from_source(&data);

        assert_eq!(
            ScriptData::parse(&mut reader, 16),
            Ok(ScriptData(vec![
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Undefined
                },
                Variable {
                    name: &[0x01, 0x02, 0x03],
                    data: Value::Null
                }
            ]))
        );
    }
}
